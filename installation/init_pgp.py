import gnupg
import os

# Initialize PGP
gpg = gnupg.GPG(homedir='/home/pangio/.gnupg')
gpg.encoding = 'utf-8'

# Generate the private key
input_data = gpg.gen_key_input(
    key_type="RSA",
    key_length=4096,
    name_real="Pangio Pi",
    name_comment="Hack the planet!",
    name_email="my@pang.io"
)
key = gpg.gen_key(input_data)

# Export the private key
with open('/home/pangio/pgp/private.key', 'w') as f:
    f.write(gpg.export_keys(key.fingerprint, True))

# Export the public key
with open('/home/pangio/pgp/public.key', 'w') as f:
    f.write(gpg.export_keys(key.fingerprint, False))

# Make it so only the Pangio user can read the keys, and open the directory.
os.chmod('/home/pangio/pgp', 0o700)
os.chown('/home/pangio/pgp', os.environ.get('PUID'), os.environ.get('PGID'))
os.chmod('/home/pangio/pgp/private.key', 0o600)
os.chown('/home/pangio/pgp/private.key', os.environ.get('PUID'), os.environ.get('PGID'))
os.chmod('/home/pangio/pgp/public.key', 0o600)
os.chown('/home/pangio/pgp/public.key', os.environ.get('PUID'), os.environ.get('PGID'))
