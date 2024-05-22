import pickle

import polars as pl
from sklearn.model_selection import train_test_split

from ml.aws.controller import download_from_s3, upload_to_s3
from ml.dataset import Dataset, FeatureTarget
from ml.logger.logging_utils import get_logger
from ml.preprocessor import BasePreprocessor

logger = get_logger(__name__)
TARGET = "click"


class DataLoader:
    def __init__(self, s3_bucket: str) -> None:
        self.s3_bucket = s3_bucket

    def load(self, s3_key: str, file_path: str) -> pl.dataframe.frame.DataFrame:
        logger.info(f"Started {file_path} data.")
        download_from_s3(s3_bucket=self.s3_bucket, s3_key=s3_key, file_path=file_path)
        df = pl.read_csv(file_path, separator=",")
        logger.info(f"Finished {file_path} data. data shape: {df.shape}")
        return df

    def train_test_split(
        self, raw_data: pl.dataframe.frame.DataFrame, preprocessor: BasePreprocessor
    ) -> Dataset:
        logger.info("Started train test split.")
        train_data, test_data = train_test_split(raw_data, test_size=0.1, shuffle=False)
        train_data, valid_data = train_test_split(
            train_data, test_size=0.1, shuffle=False
        )
        X_train = train_data[preprocessor.feature]
        Y_train = train_data[TARGET]
        X_test = test_data[preprocessor.feature]
        Y_test = test_data[TARGET]
        X_valid = valid_data[preprocessor.feature]
        Y_valid = valid_data[TARGET]

        X_train_preprocessed = preprocessor.run(X_train)
        X_valid_preprocessed = preprocessor.run(X_valid)
        X_test_preprocessed = preprocessor.run(X_test)
        logger.info("Finished train test split.")

        return Dataset(
            train=FeatureTarget(X_train_preprocessed, Y_train),
            valid=FeatureTarget(X_valid_preprocessed, Y_valid),
            test=FeatureTarget(X_test_preprocessed, Y_test),
        )

    def save(self, dataset: Dataset, s3_key: str, file_path: str) -> None:
        logger.info(f"Save dataset as {file_path}.")
        pickle.dump(dataset, open(file_path, "wb"))
        upload_to_s3(s3_bucket=self.s3_bucket, s3_key=s3_key, file_path=file_path)
