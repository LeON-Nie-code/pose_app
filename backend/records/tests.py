# Create your tests here.
import time

from django.test import TestCase

from records.models import Entry, load_record


class TestModel(TestCase):
    def test_entry(self):
        t0 = time.time()
        data = {
            'left tilt': time.time() - t0,
            'right tilt': time.time() - t0,
            'lying down in the chair': time.time() - t0,
            'bow': time.time() - t0,
            'left face': time.time() - t0,
            'right face': time.time() - t0,
            'high shoulder': time.time() - t0,
            'low shoulder': time.time() - t0,
            'supporting the table': time.time() - t0,
            'looking up': time.time() - t0,
            'normal': time.time() - t0,
        }

        record = Entry()
        load_record(record, data)
        record.save()
