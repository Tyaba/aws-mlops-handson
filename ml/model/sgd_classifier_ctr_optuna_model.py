import pickle

import optuna
from sklearn.linear_model import SGDClassifier
from sklearn.metrics import roc_auc_score

from ml.aws.controller import upload_to_s3
from ml.dataset.data_model import Dataset
from ml.logger.logging_utils import get_logger
from ml.model.base_model import BaseModel

logger = get_logger(__name__)


class SGDClassifierCTROptunaModel(BaseModel):
    def __init__(self) -> None:
        self.name = "sgd_classifier_ctr_optuna_model"
        self.model: SGDClassifier = None

    def _optuna_search(self, dataset: Dataset) -> float:
        def objective(trial: optuna.trial._trial.Trial) -> float:
            max_alpha = 0.1
            alpha = trial.suggest_float("alpha", 0, max_alpha)
            model = SGDClassifier(loss="log_loss", penalty="l2", random_state=42, alpha=alpha)
            model.fit(dataset.train.feature, dataset.train.target)
            model_pred_probas = model.predict_proba(dataset.valid.feature)[:, 1]
            score = roc_auc_score(dataset.valid.target, model_pred_probas)

            logger.info(f"alpha: {alpha} | valid roc auc score: {score}")
            return float(score)

        logger.info("Started Hyper Parameter (alpha) tuning.")
        study = optuna.create_study(direction="maximize")
        study.optimize(objective, n_trials=10)
        best_alpha = study.best_params
        return float(best_alpha["alpha"])

    def train(self, dataset: Dataset) -> None:
        logger.info("Started SGD Classifier CTR Model train.")

        logger.info("Started Optuna Hyperparmeter Tuning Search.")
        best_alpha = self._optuna_search(dataset=dataset)
        logger.info("Finished Optuna Hyperparmeter Tuning Search.")

        logger.info("Started train SGDClassifier.")
        self.model = SGDClassifier(loss="log_loss", penalty="l2", random_state=42, alpha=best_alpha)
        self.model.fit(dataset.train.feature, dataset.train.target)
        logger.info("Finished train SGDClassifier.")

        logger.info("Started validate SGDClassfier")
        accuracy = self.model.score(dataset.test.feature, dataset.test.target)
        logger.info(f"Test accuracy: {accuracy}")
        logger.info("Finished validate SGDClassfier")

        logger.info("Finished SGD Classifier CTR Model train.")

    def save(self, s3_bucket: str, s3_key: str, file_path: str) -> str:
        logger.info(f"Save {self.name} as {file_path}.")
        pickle.dump(self.model, open(file_path, "wb"))
        upload_to_s3(s3_bucket=s3_bucket, s3_key=s3_key, file_path=file_path)
        return file_path

    def load(self, file_path: str) -> None:
        logger.info(f"Load {self.name} as {file_path}.")
        self.model = pickle.load(open(file_path, "rb"))

    def predict(self, input: str) -> float:
        return float(self.model.predict_proba(input)[0][1])
