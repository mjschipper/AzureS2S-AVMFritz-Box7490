New-AzResourceGroup -Name "rg-lab-prod-aue-001" -Location "Australia East"

$subnet1 = New-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix 10.1.0.0/27
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name 'subnet-lab-prod-aue-001' -AddressPrefix 10.1.1.0/24

New-AzVirtualNetwork -Name "vnet-lab-prod-aue-001" -ResourceGroupName "rg-lab-prod-aue-001" -Location "Australia East" -AddressPrefix 10.1.0.0/16 -Subnet $subnet1, $subnet2

$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-lab-prod-aue-001" -Name "vnet-lab-prod-aue-001"

Set-AzVirtualNetwork -VirtualNetwork $vnet

New-AzLocalNetworkGateway -Name lgw-lab-prod-aue-001 -ResourceGroupName "rg-lab-prod-aue-001" -Location "Australia East" -fqdn "[yourdyndnshostname].myfritz.net" -AddressPrefix "10.1.1.0/24"

$gwpip = New-AzPublicIpAddress -Name "pip-lab-prod-aue-001" -ResourceGroupName "rg-lab-prod-aue-001" -DomainNameLabel "lab-prod-aue-001" -Location "Australia East" -AllocationMethod "Dynamic" -Sku "Basic"

$vnet = Get-AzVirtualNetwork -Name "vnet-lab-prod-aue-001" -ResourceGroupName "rg-lab-prod-aue-001"
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzVirtualNetworkGatewayIpConfig -Name ipconfig-lab-prod-aue-001 -SubnetId $subnet.Id -PublicIpAddressId $gwpip.Id

New-AzVirtualNetworkGateway -Name "vgw-lab-prod-aue-001" -ResourceGroupName "rg-lab-prod-aue-001" -Location "Australia East" -IpConfigurations $gwipconfig -GatewayType "VPN" -VpnType "PolicyBased" -GatewaySku "Basic"

Get-AzPublicIpAddress -Name "pip-lab-prod-aue-001" -ResourceGroupName "rg-lab-prod-aue-001"

$gateway1 = Get-AzVirtualNetworkGateway -Name "vgw-lab-prod-aue-001" -ResourceGroupName "rg-lab-prod-aue-001"
$local = Get-AzLocalNetworkGateway -Name "lgw-lab-prod-aue-001" -ResourceGroupName "rg-lab-prod-aue-001"

$sharedkey = "[**longkeybutnospecialchars**]"
New-AzVirtualNetworkGatewayConnection -Name "con-s2svpn-prod-aue-001" -ResourceGroupName "rg-lab-prod-aue-001" -Location "Australia East" -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -ConnectionType "IPsec" -RoutingWeight 10 -SharedKey $sharedkey


