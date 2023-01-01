from rdklib import Evaluator, Evaluation, ConfigRule, ComplianceType
import ipaddress

APPLICABLE_RESOURCES = ['AWS::EC2::VPC']

class VPC_CONFLICT_RULE(ConfigRule):
    def evaluate_change(self, event, client_factory, configuration_item, valid_rule_parameters):
        ###############################
        # Add your custom logic here. #
        ###############################

        # AWS側・オンプレミス側のCIDR情報を取り出す
        aws_vpc_cidr_str = configuration_item["configuration"]["cidrBlock"]
        onprem_vpc_cidr_str_list = valid_rule_parameters["onprem_cidr_list"]
        
        # ipaddressのIPv4Networkオブジェクトに変換
        aws_vpc_cidr = ipaddress.ip_network(aws_vpc_cidr_str)
        onprem_vpc_cidr_list = [ipaddress.ip_network(cidr_str) for cidr_str in onprem_vpc_cidr_str_list]

        # ネットワークアドレスを比較し、アドレス空間が干渉していないチェック
        for onprem_vpc_cidr in onprem_vpc_cidr_list:
            if aws_vpc_cidr.network_address == onprem_vpc_cidr.network_address:
                # 干渉している場合は、非準拠を返す
                return [Evaluation(ComplianceType.NON_COMPLIANT)]


        # 干渉していない場合は、準拠を返す
        return [Evaluation(ComplianceType.COMPLIANT)]


        # return [Evaluation(ComplianceType.NON_COMPLIANT)]

    #def evaluate_periodic(self, event, client_factory, valid_rule_parameters):
    #    pass

    def evaluate_parameters(self, rule_parameters):
        valid_rule_parameters = rule_parameters
        return valid_rule_parameters


################################
# DO NOT MODIFY ANYTHING BELOW #
################################
def lambda_handler(event, context):
    my_rule = VPC_CONFLICT_RULE()
    evaluator = Evaluator(my_rule, APPLICABLE_RESOURCES)
    return evaluator.handle(event, context)
