from scapy.all import sniff
import os


def handle_packet(packet):
    return packet.summary()


def sniff_wifi_packets():
    packets = sniff(iface=os.environ.get("PANGIO_WAP_SNIFFING_INTERFACE"), count=10, prn=handle_packet)
    wifi_data = [handle_packet(packet) for packet in packets]
    return "\n".join(wifi_data)
