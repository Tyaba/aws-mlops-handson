from typing import List

import numpy as np
import polars as pl
from scipy.sparse._csr import csr_matrix
from sklearn.feature_extraction import FeatureHasher

from ml.logger.logging_utils import get_logger
from ml.preprocessor.base_preprocessor import BasePreprocessor

logger = get_logger(__name__)


class CTRModelPreprocessor(BasePreprocessor):
    def __init__(self) -> None:
        self._feature = [
            "hour",
            "banner_pos",
            "site_id",
            "site_domain",
            "site_category",
            "app_id",
            "app_domain",
            "app_category",
            "device_id",
            "device_ip",
            "device_model",
            "device_type",
        ]
        self.feature_hasher = FeatureHasher(n_features=2**18, input_type="string")

    @property
    def feature(self) -> List[str]:
        return self._feature

    def run(self, df: pl.dataframe.frame.DataFrame) -> csr_matrix:
        logger.info("Started CTR Model Preprocessor.")
        hashed_feature = self.feature_hasher.fit_transform(np.array(df.select(pl.all().cast(str))))

        logger.info("Finished CTR Model Preprocessor.")
        return hashed_feature
