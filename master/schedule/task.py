import logging
from datetime import datetime
from enum import Enum
from uuid import uuid1


class Task(object):
    def __init__(self, genome):
        self._code = genome.code
        self._genome_id = genome.id
        self._status = Status.AVAILABLE
        self._score = None
        self._id = uuid1()
        self._assigned_time = None

        # If it takes 15 seconds more than the expected time to run, expire the assignment
        self._expiration_seconds = 0.1 * self._code.shape[0] + 15

    @property
    def status(self):
        return self._status

    @status.setter
    def status(self, value):
        if not isinstance(value, Status):
            raise ValueError("completed must be a Status")
        self._status = value
        if value == Status.ASSIGNED:
            self._assigned_time = datetime.now()

    @property
    def score(self):
        return self._score

    @score.setter
    def score(self, value):
        if not isinstance(value, float):
            raise ValueError("score must be a float")
        self._score = value

    @property
    def id(self):
        return self._id

    @property
    def code(self):
        return self._code

    @property
    def genome_id(self):
        return self._genome_id

    def check_expiration(self):
        """
        Checks to see if an assigned task has expired, and if so, it's no longer ASSIGNED
        """
        if (self.status == Status.ASSIGNED and
                (datetime.now() - self._assigned_time).total_seconds() > self._expiration_seconds):
            self.status = Status.AVAILABLE
            logging.info("Assigned task expired. Task id {task_id}".format(task_id=str(self.id)))

    def to_dict(self):
        """
        :return: dict version of this task
        """
        return dict(sequence=self._code.tolist(), id=str(self.id))


class Status(Enum):
    AVAILABLE = 1
    ASSIGNED = 2
    COMPLETED = 3
