# https://diagrams.mingrammer.com/docs/nodes/aws

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.network import Route53, ELB
from diagrams.onprem.network import Consul, Traefik
from diagrams.onprem.compute import Nomad
from diagrams.onprem.security import Vault

outformat="png"

graph_attr = {
    "layout":"dot",
    "compound":"true",
    "splines":"spline",
    "bgcolor": "white",
    "fontsize": "45",
    }

with Diagram("architecture", filename="diagram", direction="TB",outformat=outformat, graph_attr=graph_attr):
    with Cluster("vmware"):
        with Cluster("NOMAD REGION global"):
            with Cluster("SERVERS"):
                consul1_global = Consul("consul")
                nomad1_global = Nomad("nomad")
                vault1_global = Vault("vault")
            with Cluster("NOMAD DATACENTER dc1"):
                client1 = Nomad("client")
                nomad1_global - Edge(penwidth = "4", lhead = "cluster_NOMAD DATACENTER dc1", ltail="cluster_SERVERS", minlen="2") - client1
                consul1_global - Edge(penwidth = "4", lhead = "cluster_NOMAD DATACENTER dc1", ltail="cluster_SERVERS", minlen="2") - client1
                vault1_global - Edge(penwidth = "4", lhead = "cluster_NOMAD DATACENTER dc1", ltail="cluster_SERVERS", minlen="2") - client1
