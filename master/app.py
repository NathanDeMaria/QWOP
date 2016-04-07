import logging
from datetime import datetime
from flask import Flask, jsonify, request

from managers.generation_manager import GenerationManager


app = Flask(__name__)
generation_manager = GenerationManager()


@app.route('/new_task')
def new_task():
    logging.info("Requesting new task")
    next_task = generation_manager.get_next()
    return jsonify(next_task)


@app.route('/finish_task', methods=['POST'])
def finish_task():
    j = request.json
    logging.info("Finished task {task_id}".format(task_id=j['task_id']))
    generation_manager.finish_task(j['task_id'], float(j['score']))
    return "YAY"


if __name__ == '__main__':
    logging.basicConfig(filename='logs/{time}.txt'.format(
        time=datetime.now().strftime('%Y%m%d_%H%M%S')), level=logging.INFO)
    app.run()
