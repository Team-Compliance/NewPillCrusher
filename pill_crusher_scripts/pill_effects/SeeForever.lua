PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_SEE_FOREVER, "I can see forever!",
function (player, rng, _, isHorse)
    ---@diagnostic disable-next-line: param-type-mismatch
    player:UseCard(Card.CARD_SOUL_CAIN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)

    if isHorse then
        local level = Game():GetLevel()

        local roomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, false, rng, true)
        local ultraSecretRoom = level:GetRoomByIdx(roomIndex)

        ultraSecretRoom.DisplayFlags = ultraSecretRoom.DisplayFlags | 1 << 0 | 1 << 1 | 1 << 2
        level:UpdateVisibility()
    end
end)