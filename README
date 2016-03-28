= lets_encrype.pl

== Basic Usage

Clone this script and run like this:

    ./lets_encrypt.pl domain.org,www.domain.org  /var/www/domain.org/htdocs/

this script will automate the client challenge of lets encrypt and put
the files in your htdocs folder for verification.


== Apache Configuration

The recommended apache configuration including HSTS header is:

    SSLEngine on
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    SSLHonorCipherOrder on
    SSLCipherSuite 'EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA:EECDH:EDH+AESGCM:EDH:+3DES:ECDH+AESGCM:ECDH+AES:ECDH:AES:HIGH:MEDIUM:!RC4:!CAMELLIA:!SEED:!aNULL:!MD5:!eNULL:!LOW:!EXP:!DSS:!PSK:!SRP'
    SSLCertificateFile    /home/user/certs/domain.org.crt
    SSLCertificateKeyFile /home/user/certs/domain.org.key
