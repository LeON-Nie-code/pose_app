import re

username_pattern = re.compile(r'[\w\d]+')
password_pattern = re.compile(r'[\w\d]+')
mobile_pattern = re.compile(r'1\d{10}')

class RegisterMsg:
    def __init__(self, raw: dict):
        self.username = raw['username']
        self.password = raw['password']
        self.mobile = raw['mobile']

        if not (
            username_pattern.fullmatch(self.username)
            and password_pattern.fullmatch(self.password)
            and mobile_pattern.fullmatch(self.mobile)
        ):
            raise ValueError('Invalid arguments')


class LoginMsg:
    def __init__(self, raw: dict):
        self.username = raw['username']
        self.password = raw['password']

        if not (
            username_pattern.fullmatch(self.username)
            and password_pattern.fullmatch(self.password)
        ):
            raise ValueError('Invalid arguments')


class LogoutMsg:
    def __init__(self, raw: dict):
        self.username = raw['username']

        if not (
            username_pattern.fullmatch(self.username)
        ):
            raise ValueError('Invalid arguments')