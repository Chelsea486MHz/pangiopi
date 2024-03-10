from flask import Flask, request
from gsmHat import GSMHat
from . import piups
from pysstv import grayscale
from playsound import playsound
from PIL import Image
import tempfile
import qrcode
import base64
import lzma 
import gnupg
import os

gpg = gnupg.GPG(gnupghome=os.environ.get('PGP_HOME_DIRECTORY'))
gsm = GSMHat(os.environ.get('GSM_PORT'), os.environ.get('GSM_BAUDRATE'))
app = Flask(__name__)
pi_ups = piups.PiUPS()

# Load the GPG keys from the files
try:
    gpg.import_keys(open("/pgp/private.key").read())
except FileNotFoundError:
    print("Private key not found")
try:
    gpg.import_keys(open("/pgp/remote_public.key").read())
except FileNotFoundError:
    print("Public key not found")


# This function crafts a PGP payload from given data
# - LZMA compression
# - PGP signature + encryption
def craft_pgp_payload(message):
    # Convert the message to base64 and compress it
    message = base64.b64encode(bytes(message))

    # Add metadata to the message, as JSON
    GPSObj = gsm.GetActualGPS()
    data = {
        'message': message,
        'gps': {
            'utc': GPSObj.UTC,
            'latitude': GPSObj.Latitude,
            'longitude': GPSObj.Longitude,
            'speed': GPSObj.Speed,
            'course': GPSObj.Course
        },
        'battery': {
            'voltage': piups.readVoltage(),
            'capacity': piups.readCapacity()
        }
    }

    # Encode as base64 + get signature + get checksum
    data = base64.b64encode(bytes(data))
    checksum = gpg.gen_md5(data)
    signature = gpg.sign(data)

    # Craft the SMS payload
    payload = {
        'data': data,
        'md5': checksum,
        'signature': signature
    }

    # Compress the SMS payload using the LZMA algorithm
    compressed_payload = lzma.compress(bytes(payload))

    # Encrypt the payload
    fingerprint = gpg.list_keys()[0]['fingerprint']
    encrypted_payload = gpg.encrypt(compressed_payload, keys=fingerprint, always_trust=True)

    return encrypted_payload


# This API call sends encrypted data as a phone call
# It encodes the encrypted data as a QR code, then
# uses the SSTV Robot8BW mode to transmit it as sound.
#
# The GPS/GSM board has its own input jack from which
# it takes in audio for the call, so we simply need
# to play the sound over the Rasperry Pi audio jack
# and use a loopback cable to connect the two.
@app.route('/api/send/call', methods=['POST'])
def api_send_call():
    # Craft the PGP payload from the message to send
    data = craft_pgp_payload(request.get_json()['message'])

    # Split the data in chunks of 122 character
    chunk_size = 122
    chunks = [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]

    # Make a QRcode for each chunk
    tmpdir = tempfile.mkdtemp()
    for i in range(len(chunks)):
        qr = qrcode.QRCode(
            version=5,
            error_correction=qrcode.constants.ERROR_CORRECT_M,  # 15% or less errors
            box_size=5,
            border=1,
        )
        qr.add_data(chunks[i])
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white").resize((160, 120))  # Resize to 160x120 for Robot8BW

        # Encode the QRcode into SSTV Robot8BW
        filename = 'sstv_' + str(i) + '.wav'
        path_sstv = os.path.join(tmpdir, filename)
        grayscale.Robot8BW(image=img, samples_per_sec=48000, bits=16).write_wav(filename=path_sstv)

    # Make the phone call!
    call_duration = 8 * len(chunks)  # Each chunk takes 8 seconds to transmit
    gsm.Call(os.environ.get('REMOTE_NUMBER'), call_duration)
    for i in range(len(chunks)):
        filename = 'sstv_' + str(i) + '.wav'
        path_sstv = os.path.join(tmpdir, filename)
        playsound(path_sstv)
    gsm.HangUp()

    # Overwrite the sstv data on the filesystem
    with open(path_sstv, "ba+") as target:
        size = target.tell()
    with open(path_sstv, "br+") as target:
        for i in range(3):
            target.seek(0)
            target.write(os.urandom(size))

    # Remove the filesystem entries
    os.remove(path_sstv)

    return {'status': 'success'}, 200


# This API call sends a signed+encrypted SMS
# It also includes metadata obtained from the GPS module
@app.route('/api/send/sms', methods=['POST'])
def api_send_sms():
    data = craft_pgp_payload(request.get_json()['message'])

    try:
        gsm.SMS_write(data['number'], str(data))
    except Exception as e:
        return {'status': 'error', 'message': str(e)}, 500
    return {'status': 'success'}, 200
