import json
import os

class MyTest():
    def __init__(self):
        self.accountid = os.environ["accountid"]

    def create_lambda_event_for_configurationchange(self, event_dict, parameters_dict=None):
        """
            引数
                - event_dict      (dict) : AWS Configのイベント = {"configurationItem":{"item1":{}, "item2":[]},...}
                - paramaters_dict (dict) : ルールに渡す引数
            返り値
                - event           (dict) : Lambdaイベントを表すdict  
        """
        event = {
            'configRuleName':'myrule',
            'executionRoleArn': f'arn:aws:iam::{self.accountid}:role/lambda-to-awsconfig',
            'eventLeftScope': False,
            'invokingEvent': json.dumps(event_dict),
            'accountId': f'{self.accountid}',
            'configRuleArn': 'arn:aws:config:ap-northeast-1:{self.accountid}:config-rule/config-rule-xxxxxx',
            'resultToken':'token'
        }
        if parameters_dict:
            event['ruleParameters'] = json.dumps(parameters_dict)

        return event