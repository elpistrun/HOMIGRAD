-- Extra Steam Workshop content for the server.
--
-- resource.AddWorkshop accepts a single addon ID. The server downloads and
-- mounts these on top of the main collection (host_workshop_collection) so
-- that both the server and joining clients have the content. The server must
-- download them ONCE before players join (happens automatically on boot).

-- EFT Equipment Props + JMOD Armor content (models for hg armor system:
-- eft_props). This is distributed directly from the server (the .gma is
-- placed in the addons/ folder) so clients do NOT need a Workshop subscription.
--
-- The full 927MB EFT addon previously lived in cache/srcds and is now served
-- from addons/2804625575.gma so connecting players can download it.
--
-- Note: this Workshop item was removed from public visibility, so it can only
-- be fetched by accounts subscribed to it. We therefore ship it as a local
-- addon instead of resource.AddWorkshop.

-- Extra collections / addons.
resource.AddWorkshop(3401811901)
resource.AddWorkshop(3307619763)