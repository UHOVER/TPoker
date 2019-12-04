<GameFile>
  <PropertyGroup Name="showStarPoint" Type="Node" ID="1a6e4c31-d508-469a-a94a-5ac91342ec83" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="14" Speed="1.0000" ActivedAnimationName="stop">
        <Timeline ActionTag="-1201696539" Property="Position">
          <PointFrame FrameIndex="5" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="-1201696539" Property="FileData">
          <TextureFrame FrameIndex="0" Tween="False">
            <TextureFile Type="Normal" Path="pointStarAction/dip.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="5" Tween="False">
            <TextureFile Type="Normal" Path="pointStarAction/dip.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="10" Tween="False">
            <TextureFile Type="Normal" Path="pointStarAction/dip.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="14" Tween="False">
            <TextureFile Type="Normal" Path="pointStarAction/dip.png" Plist="" />
          </TextureFrame>
        </Timeline>
        <Timeline ActionTag="-1201696539" Property="BlendFunc">
          <BlendFuncFrame FrameIndex="0" Tween="False" Src="1" Dst="771" />
        </Timeline>
        <Timeline ActionTag="-1556236131" Property="Position">
          <PointFrame FrameIndex="10" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </PointFrame>
          <PointFrame FrameIndex="14" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="-1556236131" Property="Scale">
          <ScaleFrame FrameIndex="10" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="14" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="-1556236131" Property="RotationSkew">
          <ScaleFrame FrameIndex="10" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </ScaleFrame>
          <ScaleFrame FrameIndex="14" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="-1556236131" Property="FileData">
          <TextureFrame FrameIndex="0" Tween="False">
            <TextureFile Type="Normal" Path="pointStarAction/dip.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="5" Tween="False">
            <TextureFile Type="Normal" Path="pointStarAction/dip.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="10" Tween="False">
            <TextureFile Type="Normal" Path="pointStarAction/dip.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="14" Tween="False">
            <TextureFile Type="Normal" Path="pointStarAction/dip.png" Plist="" />
          </TextureFrame>
        </Timeline>
        <Timeline ActionTag="-1556236131" Property="BlendFunc">
          <BlendFuncFrame FrameIndex="0" Tween="False" Src="1" Dst="771" />
          <BlendFuncFrame FrameIndex="5" Tween="False" Src="1" Dst="771" />
          <BlendFuncFrame FrameIndex="10" Tween="False" Src="1" Dst="771" />
          <BlendFuncFrame FrameIndex="14" Tween="False" Src="1" Dst="771" />
        </Timeline>
      </Animation>
      <AnimationList>
        <AnimationInfo Name="action" StartIndex="0" EndIndex="5">
          <RenderColor A="255" R="255" G="105" B="180" />
        </AnimationInfo>
        <AnimationInfo Name="stop" StartIndex="10" EndIndex="14">
          <RenderColor A="255" R="127" G="255" B="0" />
        </AnimationInfo>
      </AnimationList>
      <ObjectData Name="Node" Tag="275" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="action" ActionTag="-1201696539" Alpha="0" Tag="276" IconVisible="False" LeftMargin="-30.0000" RightMargin="-30.0000" TopMargin="-30.0000" BottomMargin="-30.0000" ctype="SpriteObjectData">
            <Size X="60.0000" Y="60.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="Normal" Path="pointStarAction/dip.png" Plist="" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
          <AbstractNodeData Name="actionPoint" ActionTag="-1556236131" Tag="277" IconVisible="False" LeftMargin="-30.0000" RightMargin="-30.0000" TopMargin="-30.0000" BottomMargin="-30.0000" ctype="SpriteObjectData">
            <Size X="60.0000" Y="60.0000" />
            <Children>
              <AbstractNodeData Name="Text_num" ActionTag="487573965" Tag="278" IconVisible="False" LeftMargin="13.7586" RightMargin="18.2414" TopMargin="1.0504" BottomMargin="1.9496" FontSize="50" LabelText="1" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ShadowEnabled="True" ctype="TextObjectData">
                <Size X="28.0000" Y="57.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="27.7586" Y="30.4496" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4626" Y="0.5075" />
                <PreSize X="0.4667" Y="0.9500" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="255" G="0" B="0" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="Normal" Path="pointStarAction/dip.png" Plist="" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>