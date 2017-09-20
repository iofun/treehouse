import logging
import zmq

def main():

    try:
        context = zmq.Context(1)
        # Socket facing clients
        frontend = context.socket(zmq.SUB)
        frontend.bind("tcp://*:5559")
        frontend.setsockopt(zmq.SUBSCRIBE, "")
        # Socket facing services
        backend = context.socket(zmq.PUB)
        backend.bind("tcp://*:5560")
        # yo! where is the pizza?
        zmq.device(zmq.FORWARDER, frontend, backend)
    except Exception, e:
        logging.error(e)
        print("let it crash")
    finally:
        frontend.close()
        backend.close()
        context.term()

if __name__ == "__main__":
    main()
