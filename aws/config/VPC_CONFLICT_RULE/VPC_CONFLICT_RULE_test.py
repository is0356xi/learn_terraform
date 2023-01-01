import unittest
from unittest.mock import patch, MagicMock
from botocore.exceptions import ClientError
import rdklib
from rdklib import Evaluation, ComplianceType
import rdklibtest

import json
from mytest_template import mytest_utils
mytest = mytest_utils.MyTest()


##############
# Parameters #
##############

# Define the default resource to report to Config Rules
RESOURCE_TYPE = 'AWS::EC2::VPC'

#############
# Main Code #
#############

MODULE = __import__('VPC_CONFLICT_RULE')
RULE = MODULE.VPC_CONFLICT_RULE()

CLIENT_FACTORY = MagicMock()

#example for mocking S3 API calls
S3_CLIENT_MOCK = MagicMock()

def mock_get_client(client_name, *args, **kwargs):
    if client_name == 's3':
        return S3_CLIENT_MOCK
    raise Exception("Attempting to create an unknown client")

@patch.object(CLIENT_FACTORY, 'build_client', MagicMock(side_effect=mock_get_client))
class ComplianceTest(unittest.TestCase):

    rule_parameters = '{"SomeParameterKey":"SomeParameterValue","SomeParameterKey2":"SomeParameterValue2"}'

    invoking_event_iam_role_sample = '{"configurationItem":{"relatedEvents":[],"relationships":[],"configuration":{},"tags":{},"configurationItemCaptureTime":"2018-07-02T03:37:52.418Z","awsAccountId":"123456789012","configurationItemStatus":"ResourceDiscovered","resourceType":"AWS::IAM::Role","resourceId":"some-resource-id","resourceName":"some-resource-name","ARN":"some-arn"},"notificationCreationTime":"2018-07-02T23:05:34.445Z","messageType":"ConfigurationItemChangeNotification"}'

    def setUp(self):
        pass

    def test_execution(self):
        rule_parameters = {"ExecutionRoleName":"lambda-to-awsconfig"}
        invoking_event_sample = {"configurationItem":{"relatedEvents":[],"relationships":[],"configuration":{},"tags":{},"configurationItemCaptureTime":"2018-07-02T03:37:52.418Z","awsAccountId":"123456789012","configurationItemStatus":"ResourceDiscovered","resourceType":"AWS::IAM::Role","resourceId":"some-resource-id","resourceName":"some-resource-name","ARN":"some-arn"},"notificationCreationTime":"2018-07-02T23:05:34.445Z","messageType":"ConfigurationItemChangeNotification"}
        response = MODULE.lambda_handler(mytest.create_lambda_event_for_configurationchange(invoking_event_sample, rule_parameters), {})
        with open("test-res.json", "w") as f:
                json.dump(response, f, ensure_ascii=False, indent=4, sort_keys=True, separators=(',', ': '))

    
    def test_logic(self):
        # JSONファイルに保存されたconfiguration_itemのサンプルを取得
        json_ci_file = open("samples/configuration_item/vpc.json")
        configuration_item = json.load(json_ci_file)

        rule_parameters = rule_parameters = {"ExecutionRoleName":"lambda-to-awsconfig", "onprem_cidr_list":["10.0.0.0/24"]}
        invoking_event_sample = {"configurationItem": configuration_item}

        event = mytest.create_lambda_event_for_configurationchange(invoking_event_sample, rule_parameters)
        client_factory = ""
        
        response = RULE.evaluate_change(event, client_factory, configuration_item, rule_parameters)

        self.assertEqual(response, [Evaluation(ComplianceType.NON_COMPLIANT)])
        # self.assertEqual(invoking_event_sample, [Evaluation(ComplianceType.NON_COMPLIANT)])