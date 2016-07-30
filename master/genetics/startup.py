import numpy as np

from .genome import Genome
from .generation import Generation


INIT_SIZE = 50


def initial_generation(n=INIT_SIZE):
    """
    Create a starting generation
    :param n: number of Genomes in the generation
    :return: Generation
    """
    return Generation([_init_random_genome() for _ in range(n)], 0)


def _init_random_genome(length=25):
    """
    Create a genome
    :param length: number of rows in generation
    :return: random Genome
    """
    genome_array = random_code(length)
    return Genome(simplify_genome(genome_array))


def random_code(length):
    """
    Create an (n x 4) np.array of genetic code
    :param length: # rows in the genetic code
    :return: np.array of genetic code
    """
    random_array = np.random.choice(np.array([-1, 0, 1]),
                                    size=length * 4,
                                    p=np.array([.2, .6, .2]))
    return np.reshape(random_array, [length, 4])


def simplify_genome(genome_array):
    """
    Get rid of repetitions in a genome (such as a 1 followed by another 1 before a -1)
    :param genome_array: time x 4 np.array
    :return: time x 4 np.array without needless repetitions
    """
    for column in range(genome_array.shape[1]):
        on = False
        for row in range(genome_array.shape[0]):
            if genome_array[row, column] == 1:
                if on:
                    genome_array[row, column] = 0
                else:
                    on = True
            if genome_array[row, column] == -1:
                if on:
                    on = False
                else:
                    genome_array[row, column] = 0
    return genome_array
