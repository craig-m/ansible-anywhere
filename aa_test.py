import pytest
import testinfra


def test_redis_service(host):
    redis = host.service("redis")
    assert redis.is_running
    assert redis.is_enabled


def test_docker_instaleld(host):
    docker = host.package("docker-ce")
    assert docker.is_installed

def test_docker_service(host):
    dockersrv = host.service("docker")
    assert dockersrv.is_running
    assert dockersrv.is_enabled


def test_aa_readem(host):
    infotxt = host.file("/home/vagrant/readme.txt")
    assert infotxt.contains("Ansible managed")
