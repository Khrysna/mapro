import 'package:mason/mason.dart';

void run(HookContext context) {
  context.vars = {
    'project_name': context.vars['project_name'],
    'org_name': context.vars['org_name'],
    'android_namespace': context.vars['org_name'],
    'android_application_id': context.vars['org_name'],
    'ios_application_id': context.vars['org_name'],
  };
}
