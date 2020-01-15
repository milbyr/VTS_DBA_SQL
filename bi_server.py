connect()
nav=getMBean('domainRuntime:/AppRuntimeStateRuntime/AppRuntimeStateRuntime')
state=nav.getCurrentState('analytics#11.1.1','bi_server1')
print state 
