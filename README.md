# Domain

This repository contains full sources for the domain networks, hosts, sites, and
services.

Access is restricted by network topology and credentials. For a breakdown of
clearance levels, see below.

## Clearance levels

The clearance is defined by two factors: the active physical or virtual subnet,
and the access control system running in that network. Starting from the
least-restricted level onward:

- **Public: WWW**  
  The basic version of the `www` site for the domain, and the content that is
  without any restrictions (delivery or logging). Hosted on something like
  GitHub Pages or other ultra-light free service. Exists mainly for
  semi-guranteed persistent presence on the Internet.

- **Restricted: DMZ**  
  The standard open-to-internet tier of content and servers hosted only on
  controlled hardware (vps, co-location, or full-control). Has access to an
  increased swath of internal resources and content. Implements at least basic
  logging and access control if appropriate based on resource type.

- **Private: LAN**  
  The main physically isolated and secured network that implements full logging and
  observability throughout the stack, and requires either physical access or
  pre-shared keys to access remotely. Only on fully controlled physical
  hardware. Provides at least read-access to most resources.

- **Testing: LAB**  
  The testing environment running in a separate virtual network on top of a
  controlled hypervisor, with read-only access via point-to-point network to the
  LAN. Full observability and administrator-only access.

Access Control details are found within the `LAN` submodule's documentation.

## Domain and Network Topology

## Repository structure
