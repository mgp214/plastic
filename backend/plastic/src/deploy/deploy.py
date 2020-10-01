from paramiko import SSHClient
from scp import SCPClient
import os

ssh = SSHClient()

host = '66.175.219.233'
user = 'mgp214'
key_filename = R'C:\Users\mgp214\.ssh\id_rsa'
ssh.load_system_host_keys()

print(f"Connecting to {host} as {user} using keyfile {key_filename}...")
ssh.connect(host,
            username=user,
            key_filename=key_filename)

# Define progress callback that prints the current percentage completed for the file


def progress(filename, size, sent):
    print("%s\'s progress: %.2f%%   \r" %
          (filename, float(sent)/float(size)*100))


# SCPCLient takes a paramiko transport as an argument
scp = SCPClient(ssh.get_transport(), progress=progress)

cwd = os.path.join(os.getcwd(), 'src')
remote_dir = '/home/mgp214/plastic'

print(f'Clearing {remote_dir}')
ssh.exec_command(f'rm -rf {remote_dir}/src/*')

print(f'Putting {cwd} on remote at {remote_dir}')
scp.put(f'{cwd}', recursive=True,
        remote_path=remote_dir)
scp.put(f'{cwd}/../package.json', remote_path=remote_dir)
scp.put(f'{cwd}/../.env_prod', remote_path=f'{remote_dir}/.env')

scp.close()
print('done copying...')

start_cmd = f'{remote_dir} npm i && pm2 restart plastic_api'
print(f'executing {start_cmd} on remote...')
ssh.exec_command(start_cmd)

ssh.close()
print('done!')
