global function RunoffClientConnect_Init
void function RunoffClientConnect_Init()
{
 if(!Dev_CommandLineHasParm("-runoff-connect"))return
 thread RunoffClientConnect_Start()
}
void function RunoffClientConnect_Start()
{
 wait 3
 SetConVarBool("ns_auth_allow_insecure",true)
 SetConVarBool("ns_auth_allow_insecure_write",false)
 SetConVarBool("ns_report_server_to_masterserver",false)
 SetConVarBool("ns_report_sp_server_to_masterserver",false)
 ClientCommand("connect "+GetConVarString("runoff_server_address"))
 wait 30
 if(!IsFullyConnected())ClientCommand("connect "+GetConVarString("runoff_server_address"))
}
