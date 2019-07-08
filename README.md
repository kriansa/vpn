# OpenVPN Setup

This is a easy, _deploy-and-forget_ split-tunneling OpenVPN setup deployable at AWS. Traffic that
goes through it is only the one within its IP range (`10.0.2.0/24`).

It's configured to use PKI for authentication, so every user must have a valid certificate signed by
the CA.

You'll hardly need any maintenance, except when your server certificates expire. The OS is
configured to auto-update.

## Development dependencies

* Ansible
* Terraform
* AWS CLI
* gettext (for `envsubst`)

### AWS dependencies

* A S3 bucket containing PKI data, and having the following certificates:
  - ca/root-ca-cert.pem
  - certs/<$VPN_SUBDOMAIN>.<$BASE_DOMAIN_NAME>-cert.pem
  - keys/<$VPN_SUBDOMAIN>.<$BASE_DOMAIN_NAME>-key.pem
  - keys/openvpn_tls_auth.key

These certificates/keys are supposed to be created, and this project does not automatically creates
nor manages their renewall process. See OpenVPN docs to know how to create them.

## Setup

**IMPORTANT:** This is a deployment-wise setup and should be done just once, when you're creating
the VPN infrastructure from scratch. It's **not needed** to be run for each developer machine.

1. Create the certificates/keys mentionend above, as well as a S3 bucket to store them;
2. Edit the `.env` according to your needs. You **MUST** edit lines that has subshells in it because
   those are programs that does not exist on your computer;
3. Ensure that you have a valid AWS authentication set and run `$ ops/bin/setup`

## Deploying

You just need to run `$ bin/deploy` whenever you make changes to your VPN setup.

Pay attention to the logs, there are some actionable items that needs to be done on the first
deploy, such as subscribing your email to the SNS mail list for alarms.

## Adding new users

If you need to add new users to the setup, you will need to issue and sign a certificate using the
same CA that you configured on your PKI S3 bucket.

Once you have that, you can either configure it manually for each new user, or create a `.ovpn` file
that bundles together all the needed client configuration to connect to your server, and can even be
used for mobile clients. To create this file, you will first need to have locally the following
files:

- The CA certificate
- The TLS-Crypt certificate
- The client certificate
- The client key

And then you can just run the following command:

```sh
$ bin/create-client-config <CA-CERT_PATH> <TLS-CRYPT-CERT_PATH> <CLIENT-CERT_PATH> <CLIENT-KEY_PATH> <CONFIG_NAME> 
```

Then, the `.ovpn` file will be created at the `output` folder. Now, just move it to the client!

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE.md](LICENSE.md) file for
details.
