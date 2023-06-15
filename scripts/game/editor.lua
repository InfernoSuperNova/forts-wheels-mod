function UpdateEditor()
    IndexTerrainBlocks()
    CheckHeldKeys()
    if ModDebug.collision then
        EnableTerrainDebug()
    end
end