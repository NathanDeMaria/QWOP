from .genome import Status


class Generation(object):
    def __init__(self, genomes, generation_id):
        self._genomes = {str(g.id): g for g in genomes}
        self._id = generation_id

    @property
    def genomes(self):
        return self._genomes.values()

    @property
    def id(self):
        return self._id

    def get_task(self):
        """
        Get the next not assigned task. If none, returns next non completed task. If all complete, returns None
        :return: Genome
        """
        for g in self._genomes.values():
            g.check_expiration()
            if g.status == Status.AVAILABLE:
                return g

        # None are available, but at least one is assigned and waiting on an outcome
        for g in self._genomes.values():
            if g.status == Status.ASSIGNED:
                return g

        return None

    def finish_task(self, unique_id, score):
        """
        Get a score for a genome
        :param unique_id: ID of the task
        :param score: score for the genome
        :return: true if the generation is finished
        """
        g = self._genomes[unique_id]
        g.score = score
        g.status = Status.COMPLETED
        for g in self._genomes.values():
            if g.status != Status.COMPLETED:
                return False
        return True
