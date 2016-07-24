import logging
import numpy as np
from datetime import datetime
from flask import Flask, jsonify, request

from schedule.generation_manager import GenerationManager


app = Flask(__name__)
generation_manager = GenerationManager()


@app.route('/new_task')
def new_task():
    logging.info("Requesting new task")
    next_task = generation_manager.get_task()
    return jsonify(next_task)


@app.route('/finish_task', methods=['POST'])
def finish_task():
    j = request.json
    if j['score'] == 'NA':
        score = np.nan
    else:
        score = float(j['score'])
    logging.info("Finished task {task_id}. Score: {score}".format(task_id=j['task_id'], score=score))
    finished = generation_manager.finish_task(j['task_id'], score)
    if finished:
        logging.info("Generation finished, creating new generation")
    return "YAY"


if __name__ == '__main__':
    logging.basicConfig(filename='logs/{time}.txt'.format(
        time=datetime.now().strftime('%Y%m%d_%H%M%S')), level=logging.INFO)
    app.run('0.0.0.0', port=5000)
