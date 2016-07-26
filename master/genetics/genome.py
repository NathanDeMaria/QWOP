import numpy as np
from uuid import uuid1


class Genome(object):
    def __init__(self, code):
        self._code = code
        self._scores = np.array([])
        self._id = uuid1()
        self._assigned_time = None

        # If it takes 10 seconds more than the expected time to run, expire the assignment
        self._expiration_seconds = 0.1 * code.shape[0] + 10

    @property
    def score(self):
        return np.percentile(self._scores, q=100 * 2.0 / 3.0, interpolation='higher')

    @property
    def id(self):
        return self._id

    @property
    def code(self):
        return self._code

    def add_score(self, score):
        """
        Record a new score
        :param score: float score
        """
        self._scores = np.append(self._scores, score)
