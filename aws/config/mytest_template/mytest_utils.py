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

###################
# <ルール名>_test.pyにカット&ペーストする
###################
import json
from mytest_template import mytest_utils
mytest = mytest_utils.MyTest()

# 実行できるかテストを行う(IAMロールの権限など)
def test_execution(self):
        rule_parameters = {"ExecutionRoleName":"lambda-to-awsconfig"}
        invoking_event_sample = {"configurationItem":{"relatedEvents":[],"relationships":[],"configuration":{},"tags":{},"configurationItemCaptureTime":"2018-07-02T03:37:52.418Z","awsAccountId":"123456789012","configurationItemStatus":"ResourceDiscovered","resourceType":"AWS::IAM::Role","resourceId":"some-resource-id","resourceName":"some-resource-name","ARN":"some-arn"},"notificationCreationTime":"2018-07-02T23:05:34.445Z","messageType":"ConfigurationItemChangeNotification"}
        response = MODULE.lambda_handler(mytest.create_lambda_event_for_configurationchange(invoking_event_sample, rule_parameters), {})
        with open("test-res.json", "w") as f:
                json.dump(response, f, ensure_ascii=False, indent=4, sort_keys=True, separators=(',', ': '))


# 準拠・非準拠を判定するロジックのテストを行う
def test_logic(self):
    json_ci_file = open("samples/configuration_item/vpc.json")
    configuration_item = json.load(json_ci_file)

    rule_parameters = rule_parameters = {"ExecutionRoleName":"lambda-to-awsconfig", "onprem_cidr_list":["10.0.0.0/24"]}
    invoking_event_sample = {"configurationItem": configuration_item}

    event = mytest.create_lambda_event_for_configurationchange(invoking_event_sample, rule_parameters)
    client_factory = ""
    
    response = RULE.evaluate_change(event, client_factory, configuration_item, rule_parameters)

    self.assertEqual(response, [Evaluation(ComplianceType.NON_COMPLIANT)])