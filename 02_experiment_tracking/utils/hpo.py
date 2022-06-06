import argparse
import os
import pickle

import click
import numpy as np

import mlflow
from mlflow.tracking.client import MlflowClient
from urllib.parse import urlparse

from hyperopt import STATUS_OK,Trials, fmin, hp, tpe,  rand
from hyperopt.pyll import scope
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error

_inf = np.finfo(np.float64).max

mlflow.set_experiment("RandomForestHyperopt-GreenTaxi")
mlflow.set_tracking_uri("http://ec2-3-96-200-56.ca-central-1.compute.amazonaws.com:5000")
   

def load_pickle(filename):
    with open(filename, "rb") as f_in:
        return pickle.load(f_in)


@click.command(
    help="Perform hyperparameter search with Hyperopt library. Optimize dl_train target."
)
@click.option("--max-runs", type=click.INT, default=10, help="Maximum number of runs to evaluate.")
@click.option("--metric", type=click.STRING, default="rmse", help="Metric to optimize on.")
@click.option("--algo", type=click.STRING, default="tpe.suggest", help="Optimizer algorithm.")
@click.option("--seed", type=click.INT, default=42, help="Seed for the random generator")
@click.argument("data_path")    
def train(data_path, max_runs, metric, algo, seed):
    
    """
    Run hyperparameter optimization.
    """
    # create random file to store run ids of the training tasks
    tracking_client = mlflow.tracking.MlflowClient()
    
    X_train, y_train = load_pickle(os.path.join(data_path, "train.pkl"))
    X_valid, y_valid = load_pickle(os.path.join(data_path, "valid.pkl"))
    
    def new_eval(
        experiment_id, null_train_loss, null_valid_loss, null_test_loss, return_all=False
    
    ):
        """
        Create a new eval function
        :experiment_id: Experiment id for the training run
        :valid_null_loss: Loss of a null model on the validation dataset
        :test_null_loss: Loss of a null model on the test dataset.
        :return_test_loss: Return both validation and test loss if set.
        :return: new eval function.
        """
        
        def eval(params):
            
            max_depth, n_estimators, min_samples_split, min_samples_leaf, random_state = params
            with mlflow.start_run(nested=True) as child_run:
                p = mlflow.projects.run(
                    uri=".",
                    entry_point="train",
                    run_id=child_run.info.run_id,
                    parameters={
                        "training_data": X_train,
                        "max_depth": str(max_depth),
                        "n_estimators": str(n_estimators),
                        "min_samples_split": str(min_samples_split),
                        "min_samples_leaf": str(min_samples_leaf),
                        "random_state": str(random_state)
                    },
                    experiment_id=experiment_id,
                    use_conda=False,  # We are already in the environment
                    synchronous=False,  # Allow the run to fail if a model is not properly created
                )
                succeeded = p.wait()
                mlflow.log_params({"max_depth": max_depth, "n_estimators": n_estimators})
            
            if succeeded:
                training_run = tracking_client.get_run(p.run_id)
                metrics = training_run.data.metrics
                # cap the loss at the loss of the null model
                train_loss = min(null_train_loss, metrics["train_{}".format(metric)])
                valid_loss = min(null_valid_loss, metrics["val_{}".format(metric)])
                test_loss = min(null_test_loss, metrics["test_{}".format(metric)])
            else:
                # run failed => return null loss
                tracking_client.set_terminated(p.run_id, "FAILED")
                train_loss = null_train_loss
                valid_loss = null_valid_loss
                test_loss = null_test_loss
                
            mlflow.log_metrics(
                {
                    "train_{}".format(metric): train_loss,
                    "val_{}".format(metric): valid_loss,
                    "test_{}".format(metric): test_loss,
                }
            )
            
            if return_all:
                return train_loss, valid_loss, test_loss
            else:
                return valid_loss
            
        return eval


    search_space = {
            'max_depth': scope.int(hp.quniform('max_depth', 1, 20, 1)),
            'n_estimators': scope.int(hp.quniform('n_estimators', 10, 50, 1)),
            'min_samples_split': scope.int(hp.quniform('min_samples_split', 2, 10, 1)),
            'min_samples_leaf': scope.int(hp.quniform('min_samples_leaf', 1, 4, 1)),
            'random_state': 42
    }

    with mlflow.start_run() as run:
        experiment_id = run.info.experiment_id
        # Evaluate null model first.
        train_null_loss, valid_null_loss, test_null_loss = new_eval(
            experiment_id, _inf, _inf, _inf, True
        )(params=[0, 0, 0, 0, 42])
        
        best = fmin(
            fn=new_eval(experiment_id, train_null_loss, valid_null_loss, test_null_loss),
            space=search_space,
            algo=tpe.suggest if algo == "tpe.suggest" else rand.suggest,
            max_evals=max_runs,
        )
        
        mlflow.set_tag("best params", str(best))
        # find the best run, log its metrics as the final metrics of this run.
        client = MlflowClient()
        runs = client.search_runs(
            [experiment_id], "tags.mlflow.parentRunId = '{run_id}' ".format(run_id=run.info.run_id)
        )
        best_val_train = _inf
        best_val_valid = _inf
        best_val_test = _inf
        best_run = None
        
        for r in runs:
            if r.data.metrics["val_rmse"] < best_val_valid:
                best_run = r
                best_val_train = r.data.metrics["train_rmse"]
                best_val_valid = r.data.metrics["val_rmse"]
                best_val_test = r.data.metrics["test_rmse"]
        mlflow.set_tag("best_run", best_run.info.run_id)
        mlflow.log_metrics(
            {
                "train_{}".format(metric): best_val_train,
                "val_{}".format(metric): best_val_valid,
                "test_{}".format(metric): best_val_test,
            }
        )



if __name__ == "__main__":
    train()

