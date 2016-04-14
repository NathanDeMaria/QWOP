from .task import Status


class TaskSet(object):
    def __init__(self, tasks):
        self._task_dict = {str(t.id): t for t in tasks}

    @property
    def tasks(self):
        return self._task_dict.values()

    def get_task(self):
        """
        Get the next task that's not assigned
        :return: next Task, or None if all are assigned
        """
        for t in self.tasks:
            t.check_expiration()
            if t.status == Status.AVAILABLE:
                return t
        return None

    def finish_task(self, task_id, score):
        """
        Mark a task as completed, save the score
        :param task_id: ID of the task
        :param score: score that the task resulted in
        """
        task = self._task_dict[task_id]
        task.score = score
        task.status = Status.COMPLETED

    def is_finished(self):
        """
        Check if the tasks are finished
        :return: True if all the tasks are finished
        """
        for t in self.tasks:
            if t.status != Status.COMPLETED:
                return False
        return True
