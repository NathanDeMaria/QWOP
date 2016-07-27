import logging
from operator import add

from genetics.runner import current_generation, next_generation
from .task import Task
from .task_set import TaskSet


class GenerationManager(object):
    def __init__(self):
        self._current_generation = current_generation()
        self._task_set = _create_task_set(self._current_generation)

    def get_task(self):
        """
        Get the next not assigned task. Tells slave to wait if there's nothing ready
        """
        next_task = self._task_set.get_task()
        if not next_task:
            logging.info("No available tasks")
            return dict(message="Patience")

        logging.info("Assigning task {task_id}".format(task_id=next_task.id))
        return next_task.to_dict()

    def finish_task(self, unique_id, score):
        """
        Get a score for a genome
        :param unique_id: ID of the task
        :param score: score for the genome
        :return: true if the generation is finished
        """
        self._task_set.finish_task(unique_id, score)
        finished = self._task_set.is_finished()
        if finished:
            self._finish_generation()
            return True
        return False

    def _finish_generation(self):
        for t in self._task_set.tasks:
            genome = self._current_generation.get_genome(t.genome_id)
            if genome:
                genome.add_score(t.score)
            else:
                logging.warn("Genome {genome_id} missing".format(genome_id=t.genome_id))
        self._current_generation = next_generation(self._current_generation)
        self._task_set = _create_task_set(self._current_generation)


def _create_tasks(genome, n=1):
    """
    Create a set of tasks for a genome
    :param genome: Genome
    :param n: number of tasks
    :return: yields tasks
    """
    if genome.has_score:
        return [Task(genome) for _ in range(n)]
    return []


def _create_task_set(generation):
    """
    Get list of tasks for a generation
    :param generation: Generation
    :return: TaskList for the generation
    """
    task_lists = [_create_tasks(genome) for genome in generation.genomes]
    return TaskSet(reduce(add, task_lists))
