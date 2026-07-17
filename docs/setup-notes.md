
Create the AAP project pointing to the Git repo.

![Image](./setup-images/1-aap-create-project.png)

https://aap-aap.apps.ocp-mgmt.rh-lab.morey.tech/execution/projects/create
---

Create the empty cloud provider inventory

https://aap-aap.apps.ocp-mgmt.rh-lab.morey.tech/execution/infrastructure/inventories/inventory/create

![Image](./setup-images/2-aap-cloud-provider-inventory.png)
---

Create the execution environment with TF in it.

https://aap-aap.apps.ocp-mgmt.rh-lab.morey.tech/execution/infrastructure/execution-environments/add

quay.io/froberge/ansible-terraform-demo:0.2

![Image](./setup-images/3-aap-create-ee.png)
---

Create AWS access credential

Provision environment on demo.redhat.com
https://catalog.demo.redhat.com/catalog/babylon-catalog-prod/order/sandboxes-gpte.sandbox-open.prod

https://aap-aap.apps.ocp-mgmt.rh-lab.morey.tech/execution/infrastructure/credentials/create

![Image](./setup-images/4-aap-create-aws-cred.png)
---

Create AWS SSH cred

https://us-east-2.console.aws.amazon.com/ec2/home?region=us-east-2#CreateKeyPair:

![Image](./setup-images/5-aws-create-key-pair.png)
![Image](./setup-images/5-aap-create-aws-machine-creds.png)
---

Create AWS dynamic inventory

1. Create blank inventory
2. Open inventory, goto sources.
   1. Select Source `Amazon EC2`
   2. Set Execution Environment to `Default ...`
   3. Set Credential to `AWS` (created earlier)
   4. Set source variables
      
      ```yaml
      ---
      regions: us-east-2
      keyed_groups:
      - key: tags.type
      prefix: tag
      ```

![Image](./setup-images/6-aap-aws-dynamic-inventory.png)
---

## ServiceNow Set Up

Business Rule - Trigger based on changes in tables
- https://xxxxxxx.service-now.com/now/nav/ui/classic/params/target/sys_script_list.do
- Create a table for the purpose of the demo
- The business rule calls the `RESTMessage` object


REST Message
- https://xxxxxxx.service-now.com/now/nav/ui/classic/params/target/sys_rest_message.do

https://xxxxxxx.service-now.com/x_rhtpp_nmorey_a_0_virtual_machine_requests.do?sys_id=-1&sysparm_view=Default%20view&sysparm_view_forced=true

https://ven05434.service-now.com/now/nav/ui/classic/params/target/sys_db_object.do%3Fsys_id%3Dea6f53afc3187a10b1876c0fb0013178%26sysparm_record_target%3Dsys_db_object%26sysparm_record_row%3D2%26sysparm_record_rows%3D2%26sysparm_record_list%3Dsys_scope%253D673a1caec3983610b1876c0fb001311a%255EORDERBYname

https://ven05434.service-now.com/x_rhtpp_nmorey_a_0_web_server_requests.do?sys_id=-1&sysparm_view=Default%20view&sysparm_view_forced=true

```
{
    "extra_vars": "{\"infra_state\": \"${infra_state}\", \"request_id\": \"${request_id}\",\"server_count\": \"${server_count}\",\"project_name\": \"${project_name}\"}"
}
```