# New .ee WHOIS disclosure policy activation (internetee/registry#2969).
# DISCLOSURE_POLICY_ACTIVE_FROM must be an ISO 8601 timestamp with offset,
# e.g. "2027-01-18T00:00:00+02:00". Unset/blank keeps the legacy policy;
# a malformed value aborts boot rather than silently picking a policy.
DisclosurePolicy.load_from_env
