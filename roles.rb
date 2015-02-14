role :mesos do
  $myxp.get_deployed_nodes('master') + $myxp.get_deployed_nodes('slave')
end

role :mesos_master do
  $myxp.get_deployed_nodes('master')
end

role :mesos_slave do
  $myxp.get_deployed_nodes('slave')
end
