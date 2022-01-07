## Adding Org3 to the cloud network

You can use the `addCSP3.sh` script to add another organization to the Fabric cloud network. The `addCSP3.sh` script generates the CSP3 crypto material, creates an Org3 organization definition, and adds CSP 3 to a channel on the cloud network.

You first need to run `./network.sh up createChannel` in the `cloud-network` directory before you can run the `addCSP3.sh` script.

```
./network.sh up createChannel
cd addCSP3
./addCSP3.sh up
```

If you used `network.sh` to create a channel other than the default `cloudchannel`, you need pass that name to the `addCSP3.sh` script.
```
./network.sh up createChannel -c channel1
cd addCSP3
./addCSP3.sh up -c channel1
```

You can also re-run the `addCSP3.sh` script to add Org3 to additional channels.
```
cd ..
./network.sh createChannel -c channel2
cd addCSP3
./addCSP3.sh up -c channel2
```

For more information, use `./addCSP3.sh -h` to see the `addCSP3.sh` help text.
