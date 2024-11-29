# test.py
from SendCode.send import SendCode

def test_SendCode():
    result = SendCode('1234', '18610776716')
    print(result)
if __name__ == '__main__':
    test_SendCode()