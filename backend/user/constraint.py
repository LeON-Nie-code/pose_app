import re

username_pattern = re.compile(r'^[\w-]+\Z')
password_pattern = re.compile(r'[\w\d!@#$%^*&+-]+')
mobile_pattern = re.compile(r'1\d{10}')
name_pattern = re.compile(r'\w+')
email_pattern = re.compile(r'[\w-]+@[\w-]+\.[\w-]+')
school_pattern = re.compile(r'[\w-]+')
gender_pattern = re.compile(r'Male|Female')


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


class ProfileMsg(dict):
    def __init__(self, raw: dict):
        super(ProfileMsg, self).__init__()

        if name_pattern.fullmatch(val := raw.get('name')):
            self['name'] = val
        if email_pattern.fullmatch(val := raw.get('email')):
            self['email'] = val
        if school_pattern.fullmatch(val := raw.get('school')):
            self['school'] = val
        if gender_pattern.fullmatch(val := raw.get('gender')):
            self['gender'] = val
