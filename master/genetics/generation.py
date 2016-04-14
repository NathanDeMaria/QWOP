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

    def get_genome(self, genome_id):
        """
        Get a genome by id
        :param genome_id: uuid of genome
        :return: Genome, None if missing
        """
        return self._genomes.get(str(genome_id))
