from tornado import gen, testing
from tornado.testing import gen_test
import tornado
import tornado.ioloop
import tornado.httpclient
import ujson as json


class MyTestCase(testing.AsyncTestCase):
    client = testing.AsyncHTTPClient()
    name = 'mercedes15'
    url = "http://localhost:8098/types/cars/buckets/sport/keys/{}".format(name)

    def setUp(self):
        print("Setting up")
        super().setUp()
        tornado.ioloop.IOLoop.current().run_sync(self.put)

    def tearDown(self):
        print("Tearing down")
        super().tearDown()
        request = tornado.httpclient.HTTPRequest(self.url, method='DELETE')
        response = yield self.client.fetch(request)
        print("Response just after sending DELETE {}".format(response))
        tornado.ioloop.IOLoop.current().stop()

    @gen.coroutine
    def put(self):
        print("Putting")
        data = '{"name_s":' + self.name + ', "model_i":2018, "leader_b":true}'
        headers = {'Content-Type': 'application/json'}
        request = tornado.httpclient.HTTPRequest(self.url, method='PUT', headers=headers, body=json.dumps(data))
        response = yield self.client.fetch(request)
        print("Response just after sending PUT {}".format(response))
        return response

    @gen_test
    def test_find_one(self):
        print("Finding")
        response = yield self.client.fetch(
            "http://localhost:8098/search/query/famous?wt=json&q=name_s:{}".format(self.name))
        print(response)
        self.assertIn("name_s:{}".format(self.name), str(response.body))