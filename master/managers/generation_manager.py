import logging

from genetics.runner import next_generation, current_generation
from genetics.genome import Status


class GenerationManager(object):
    def __init__(self):
        self._current_generation = current_generation()

    def get_next(self):
        task = self._current_generation.get_task()
        if task is None:
            logging.info("Generation finished, waiting on new generation")
            return "Just finished a generation, working on new one"
        if task.status is Status.AVAILABLE:
            task.status = Status.ASSIGNED
            logging.info("Task {genome_id} assigned".format(genome_id=task.id))
            return task.to_dict()
        elif task.status is Status.ASSIGNED:
            logging.info("Generation waiting on a task")
            return "Just wait plz"
        else:
            raise ValueError("Unknown task status")

    def finish_task(self, unique_id, score):
        finished_all = self._current_generation.finish_task(unique_id, score)
        if finished_all:
            logging.info("Generation finished, creating new generation")
            self._current_generation = next_generation(self._current_generation)
