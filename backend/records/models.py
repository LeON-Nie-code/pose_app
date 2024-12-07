from datetime import timedelta

from django.db import models

from user.models import User


# Create your models here.
class Entry(models.Model):
    class Meta:
        db_table = 'pose_records'

    left_tilt = models.DurationField()
    right_tilt = models.DurationField()
    lying_down_in_the_chair = models.DurationField()
    bow = models.DurationField()
    left_face = models.DurationField()
    right_face = models.DurationField()
    high_shoulder = models.DurationField()
    low_shoulder = models.DurationField()
    supporting_the_table = models.DurationField()
    looking_up = models.DurationField()
    normal = models.DurationField()

    taken_at = models.DateTimeField(auto_now_add=True)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()

    user = models.ForeignKey(User, on_delete=models.CASCADE)


def load_record(record: Entry, data: dict):
    """
    将网络请求搬运到后端模型
    """

    def float2duration(category: str) -> timedelta:
        return timedelta(seconds=float(data[category]))

    record.left_tilt = float2duration('left tilt')
    record.right_tilt = float2duration('right tilt')
    record.lying_down_in_the_chair = float2duration('lying down in the chair')
    record.bow = float2duration('bow')
    record.left_face = float2duration('left face')
    record.right_face = float2duration('right face')
    record.high_shoulder = float2duration('high shoulder')
    record.low_shoulder = float2duration('low shoulder')
    record.supporting_the_table = float2duration('supporting the table')
    record.looking_up = float2duration('looking up')
    record.normal = float2duration('normal')
def dump_record(record: Entry):
    data = {
        'left tilt': record.left_tilt,
        'right tilt': record.right_tilt,
        'lying down in the chair': record.lying_down_in_the_chair,
        'bow': record.bow,
        'left face': record.left_face,
        'right face': record.right_face,
        'high shoulder': record.high_shoulder,
        'low shoulder': record.low_shoulder,
        'supporting the table': record.supporting_the_table,
        'looking up': record.looking_up,
        'normal': record.normal,
    }
    return {k: v.total_seconds() for k, v in data.items()}
