const { ethers, upgrades } = require('hardhat')

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  // type proxy address for upgrade contract
  // deployer must have upgrade access
  const upgradeProxy = null
  // testnet: '0xE63bac07953C900764B81E4dd8E4b9781EAF23ee'

  const { save, get } = deployments
  const { deployer } = await getNamedAccounts()
  const chainId = await getChainId()

  console.log('')

  // noinspection PointlessBooleanExpressionJS
  if (!upgradeProxy) {
    console.log(`== Brickly deployment to ${hre.network.name} ==`)
    try {
      const deplpoyment = await get('Brickly')
      console.log(
        `Brickly already deployed to ${hre.network.name} at ${deplpoyment.address}`
      )
      return
    } catch (e) {
      // not deployed yet
    }

    console.log('ChainId:', chainId)
    console.log('Deployer address:', deployer)

    const Brickly = await ethers.getContractFactory('Brickly')
    const brickly = await upgrades.deployProxy(
      Brickly,
      [],
      {
        kind: 'uups',
      }
    )

    await brickly.deployed()

    const artifact = await hre.artifacts.readArtifact('Brickly')

    await save('Brickly', {
      address: brickly.address,
      abi: artifact.abi,
    })

    let receipt = await brickly.deployTransaction.wait()
    console.log(
      `Brickly proxy deployed at: ${brickly.address} (block: ${receipt.blockNumber
      }) with ${receipt.gasUsed.toNumber()} gas`
    )
  } else {
    console.log(`==== Brickly upgrade at ${hre.network.name} ====`)
    console.log(`Proxy address: ${upgradeProxy}`)

    // try to upgrade
    const Brickly = await ethers.getContractFactory('Brickly')
    const brickly = await upgrades.upgradeProxy(upgradeProxy, Brickly)

    const artifact = await hre.artifacts.readArtifact('Brickly')

    await save('Brickly', {
      address: brickly.address,
      abi: artifact.abi,
    })

    let receipt = await brickly.deployTransaction.wait()
    console.log(
      `Brickly upgraded through proxy: ${brickly.address} (block: ${receipt.blockNumber
      }) with ${receipt.gasUsed.toNumber()} gas`
    )

    // hardhat verify --network r.. 0x
    // npx hardhat verify --network <network> <address>
    // npx hardhat verify --network modeTestnet 0xE63bac07953C900764B81E4dd8E4b9781EAF23ee
  }
}

module.exports.tags = ['Brickly']
