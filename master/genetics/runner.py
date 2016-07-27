import os
import pickle
import logging
import numpy as np

from .startup import initial_generation, simplify_genome, random_code
from genetics.genome import Genome
from genetics.generation import Generation


GENEALOGY = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'genealogy')


def next_generation(generation):
    """
    :param generation: current Generation
    :return: next Generation
    """
    scores = np.array([g.score for g in generation.genomes])
    logging.info("Generation {generation_id} average score: {score}".format(generation_id=generation.id,
                                                                            score=np.nanmean(scores)))
    logging.info("Generation size: {size}".format(size=len(scores)))
    save_generation(generation)

    does_survive = to_probability(scores, len(scores) * 2.0 / 3.0) > np.random.uniform(size=len(scores))
    has_baby = to_probability(scores, len(scores) * 1.0 / 3.0) > np.random.uniform(size=len(scores))

    parents = [parent for parent, is_parent in zip(generation.genomes, has_baby) if is_parent]
    babies = [make_baby(parent.code) for parent in parents]

    survivors = [parent for parent, survives in zip(generation.genomes, does_survive) if survives]
    logging.info("Generation results: {survivors} survivors\t{parents} parents\t{babies}babies".format(
        survivors=len(survivors),
        parents=len(parents),
        babies=len(babies)
    ))
    return Generation(babies + survivors, generation.id + 1)


def make_baby(parent_code, mutate_probability=.02):
    """
    Make babies based on the parent
    :param parent_code: parent genome's code
    :param mutate_probability: overall probability an entry flips
    :return: baby genome
    """
    baby_code = parent_code.copy()
    for row in range(baby_code.shape[0]):
        # scaling probabilities so mutations happen more often at the end
        row_probability = (row / baby_code.shape[0] + 0.5) * mutate_probability
        flips = np.random.uniform(size=baby_code.shape[1]) > row_probability
        for col in range(baby_code.shape[1]):
            if flips[col]:
                options = [x for x in [-1, 0, 1] if x != baby_code[row, col]]
                baby_code[row, col] = options[np.random.randint(2)]

    # Shrink 1/3 of the time, grow 1/3 of the time, stay the same 1/3
    # Generations should figure out which one is better ;)
    length_option = np.random.uniform()
    if length_option < 1 / 3.0:
        additional_sequence = random_code(5)
        baby_code = np.concatenate([baby_code, additional_sequence])
    elif length_option < 2 / 3.0:
        baby_code = baby_code[:-5]

    simplified_code = simplify_genome(baby_code)
    return Genome(simplified_code)


def current_generation():
    """
    Load the most recent generation from a pickle, or create the first one
    :return: current generation
    """

    generation_files = [f for f in os.listdir(GENEALOGY) if f.endswith('.pkl')]
    if len(generation_files) == 0:
        logging.info("No generations. Creating an initial generation")
        return initial_generation()

    generation_files = sorted(generation_files,
                              key=lambda filename: int(os.path.splitext(os.path.basename(filename))[0]))
    with open(os.path.join(GENEALOGY, generation_files[-1]), 'rb') as gf:
        logging.debug("Loading generation {generation}".format(generation=generation_files[-1]))
        generation = next_generation(pickle.load(gf))
    return generation


def save_generation(generation):
    """
    Save the generation
    :param generation: generation
    """
    with open(os.path.join(GENEALOGY, '{:04d}.pkl'.format(generation.id)), 'wb') as f:
        pickle.dump(generation, f)


def to_probability(scores, expected_sum, temperature=1):
    """
    Adjust the scores to a probability
    :param scores: np.array of scores
    :param expected_sum: sum of probabilities
    :param temperature: degree to which better scores mean better probabilities
    :return: np.array of probabilities
    """
    good_scores = scores[~np.isnan(scores)]
    e = np.exp(good_scores / float(temperature))
    scaled = e / e.sum()
    max_multiplier = 1.0 / scaled.max()

    if expected_sum < max_multiplier:
        adjusted_scores = scaled * expected_sum
    else:
        tilted_up = scaled * max_multiplier
        adjustment = (expected_sum - tilted_up.sum()) / float(tilted_up.size - tilted_up.sum())
        adjusted_scores = tilted_up * (1.0 - adjustment) + adjustment

    final_scores = np.zeros_like(scores)
    final_scores[~np.isnan(scores)] = adjusted_scores
    return final_scores
