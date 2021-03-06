$subscriptionname = 'xxxxxxxxxxx'
$setuplocation = 'East US'
$resourcegroup = 'EastUS_RG'
$yourisppublicip = 'xxx.xxx.xxx.xxx'
$sharedkey = 'xxxxxxxxxxxxxxxxx'
$azurepubipdnsname = 'xxxxxxxxx'

Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionName $subscriptionname

New-AzureRmResourceGroup -Name $resourcegroup -Location $setuplocation

$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix 10.1.0.0/28
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet01' -AddressPrefix 10.1.1.0/24

New-AzureRmVirtualNetwork -Name AzureVNET -ResourceGroupName $resourcegroup `
-Location $setuplocation -AddressPrefix 10.1.0.0/16 -Subnet $subnet1, $subnet2

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourcegroup -Name AzureVNET

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

New-AzureRmLocalNetworkGateway -Name EndpointLNG -ResourceGroupName $resourcegroup `
-Location $setuplocation -GatewayIpAddress $yourisppublicip -AddressPrefix 192.168.1.0/24

$gwpip= New-AzureRmPublicIpAddress -Name AzureVNG_PubIP -ResourceGroupName $resourcegroup -DomainNameLabel $azurepubipdnsname -Location $setuplocation -AllocationMethod Dynamic

$vnet = Get-AzureRmVirtualNetwork -Name AzureVNET -ResourceGroupName $resourcegroup
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$gwipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name AzureVNG_Ipconfig -SubnetId $subnet.Id -PublicIpAddressId $gwpip.Id

New-AzureRmVirtualNetworkGateway -Name AzureVNG -ResourceGroupName $resourcegroup `
-Location $setuplocation -IpConfigurations $gwipconfig -GatewayType Vpn `
-VpnType PolicyBased -GatewaySku Basic

Get-AzureRmPublicIpAddress -Name AzureVNG_PubIP -ResourceGroupName $resourcegroup

$gateway1 = Get-AzureRmVirtualNetworkGateway -Name AzureVNG -ResourceGroupName $resourcegroup
$local = Get-AzureRmLocalNetworkGateway -Name EndpointLNG -ResourceGroupName $resourcegroup

New-AzureRmVirtualNetworkGatewayConnection -Name Azure2Local -ResourceGroupName $resourcegroup `
-Location $setuplocation -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local `
-ConnectionType IPsec -RoutingWeight 10 -SharedKey $sharedkey
