#!/usr/bin/env python3

import os
import argparse
import shutil
from hashlib import md5


def generate_digest(username: str, realm: str, password: str):
    data = f"{username}:{realm}:{password}".encode("utf-8")
    hash_data = md5(data).hexdigest()
    digest = f"{username}:{realm}:{hash_data}"

    return digest


def update_variable(file: str, variable_name: str, value: str):
    if not os.path.exists(file):
        raise FileNotFoundError(f"{file} file not found")

    lines: list[str] = []
    with open(file, "r") as f:
        for line in f.readlines():
            if line.startswith(variable_name):
                lines.append(f"{variable_name}={value}")
            else:
                lines.append(line)

    with open(file, "w") as f:
        f.writelines(lines)


def copy_file(
    source_file: str, target_file: str, force: bool = False, skip_existing: bool = True
):
    if os.path.exists(target_file):
        if skip_existing:
            return

        elif not force:
            raise FileExistsError(
                f"Target file {target_file} already exists. Use --force to overwrite."
            )

    try:
        shutil.copy(source_file, target_file)

    except IOError as e:
        print(f"Error copying file: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="General toolbox for Traefik Stack project"
    )
    subparsers = parser.add_subparsers(dest="command")

    copy_parser = subparsers.add_parser("copy")
    gen_parser = subparsers.add_parser("gen")

    # Copy
    copy_parser.add_argument("source", metavar="source", type=str, help="source file")
    copy_parser.add_argument("target", metavar="target", type=str, help="target file")

    copy_parser.add_argument(
        "--force",
        "-f",
        action="store_true",
        help="don't ask, just do it",
    )
    copy_parser.add_argument(
        "--skip-existing",
        "-n",
        action="store_true",
        help="don't operate on existing files",
    )

    # Generate
    gen_parser.add_argument(
        "--username",
        "-u",
        metavar="username",
        type=str,
        help="username for traefik dashboard",
    )
    gen_parser.add_argument(
        "--password",
        "-p",
        metavar="password",
        type=str,
        help="password for traefik dashboard",
    )
    gen_parser.add_argument(
        "--save",
        "-s",
        action="store_true",
        help="Save result to .env",
    )

    args = parser.parse_args()

    if args.command == "copy":
        if args.source and args.target:
            copy_file(args.source, args.target, args.force, args.skip_existing)
        else:
            parser.print_help()

    if args.command == "gen":
        if not args.username:
            username = input("Username for Traefik Dashboard: ")

        if not args.password:
            password = input("Password for Traefik Dashboard: ")

        digest = generate_digest(
            username=username or args.username,
            password=password or args.password,
            realm="traefik",
        )
        if args.save:
            update_variable(
                file=".env", variable_name="TRAEFIK_DIGESTAUTH_USERS", value=digest
            )
        else:
            print(f"Generated digest: {digest}")
