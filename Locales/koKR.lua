local L = LibStub("AceLocale-3.0"):NewLocale("MapHighlights", "koKR")
if not L then return end
-- Translated by labrie75

L["enable"] = "활성화"
L["scale"] = "크기"
L["alpha"] = "투명도"
L["textFont"] = "글꼴"
L["textSize"] = "글자 크기"
L["show"] = "표시"
L["enableColor"] = "색상 활성화"
L["text"] = "글자"
L["highlight"] = "강조"
L["animation"] = "애니메이션"
L["color"] = "색상"
L["top"] = "위"
L["bottom"] = "아래"
L["left"] = "왼쪽"
L["right"] = "오른쪽"
L["center"] = "가운데"
L["offset"] = "위치 보정"
L["glow"] = "발광"
L["openOptions"] = "설정 열기"

-- Main menu
L["tab_settings"] = "설정"
L["tab_mapHighlights"] = "지도 강조"
L["tab_other"] = "기타 옵션"

-- map highlights
--
-- global settings
L["header_globalHighlights"] = "전역 강조 설정"
L["descr_globalHighlights"] = "모든 지도 강조에 적용되는 설정.|n각 강조의 개별 설정으로 덮어쓸 수 있습니다."
L["dropdown_textOutline"] = "글자 외곽선"
L["outlineNone"] = "없음"
L["outlineThin"] = "가늘게"
L["outlineThick"] = "두껍게"
L["outlineThinOld"] = "가늘게 (이전)"
L["outlineThickOld"] = "두껍게 (이전)"
--
-- individual settings
L["header_hlSelection"] = "개별 강조 설정"
L["header_animation"] = "애니메이션"
L["descr_anim"] = "미리보기를 클릭해 애니메이션 재생"
L["dropdown_animPlayback"] = "애니메이션 재생 시점"
L["animPlayback_onBoth"] = "지도 열 때 & 클릭 시"
L["animPlayback_onMap"] = "지도 열 때만"
L["animPlayback_onClick"] = "클릭 시에만"
L["animPlayback_loop"] = "반복"

L["dropdown_animStyle"] = "애니메이션 스타일"
L["animStyle1"] = "축소 & 페이드"
L["animStyle2"] = "확대 & 페이드"
L["animStyle3"] = "파동"
L["animStyle4"] = "깜빡임"

L["iconScale"] = "강조 크기"
L["dropdown_hlStyle"] = "강조 스타일"
L["hlStyle_glowingFG"] = "발광 전경"
L["hlStyle_solidBG"] = "단색 배경"
L["hlStyle_glowingBG"] = "발광 배경"

L["dropdown_hlTexture"] = "강조 텍스처"
L["hlTexture_1"] = "아이콘과 동일"
L["hlTexture_2"] = "부드러운 원형"
L["hlTexture_3"] = "단색 노랑 원형"
L["hlTexture_4"] = "단색 갈색 원형"

L["textScale"] = "글자 크기 배율"
L["textPosition"] = "글자 위치"
L["textCustom"] = "글꼴 사용자 지정"
L["textLevel"] = "글자 레이어"
L["descr_textLevel"] = "값이 높을수록 글자가 다른 아이콘 위에 표시됩니다.|n|n2200~2800 권장.|n2800 초과 시 플레이어 화살표를 가립니다."

-- highlight group names
L["Navigation"] = "탐색"
L["Locations"] = "지점"
L["Objectives"] = "목표"
L["Other"] = "기타"
-- highlight names
L["Waypoint"] = "경유지"
L["Flightmaster"] = "비행 조련사"
L["Flightmaster (undiscovered)"] = "비행 조련사 (미발견)"
L["Dungeon"] = "던전"
L["Raid"] = "공격대"
L["Delve"] = "구렁"
L["Lair"] = "소굴"
L["Bountiful Delve"] = "풍요로운 구렁"
L["Quest Hub"] = "퀘스트 지점"
L["Zone Portal"] = "지역 차원문"
L["Cave Exit (Up)"] = "동굴 출구 (위)"
L["Cave Exit (Down)"] = "동굴 출구 (아래)"
L["Rare Encounter"] = "희귀"
L["WQ Special Assignment"] = "특별 과제"
L["S.C.R.A.P. Heap (active)"] = "S.C.R.A.P. 더미 (활성)"
L["S.C.R.A.P. Heap (inactive)"] = "S.C.R.A.P. 더미 (비활성)"
L["Treasure Goblin Spawn"] = "보물 고블린 출현"
L["Ritual Site"] = "의식 지점"

L["checkbox_playerLocation"] = "플레이어 위치 강조"
L["descr_playerLocation"] = "지도를 열거나 마우스 클릭 시 위치 화살표를 강조합니다."
L["checkbox_battlefieldMap"] = "전장 지도에도 포함"
L["descr_battlefieldMap"] = "월드맵 뿐 아니라 전장 지도(존맵)에도 모든 강조를 표시합니다."

L["chatCommands"] = "채팅 명령어:"
L["preview"] = "미리보기"
L["disabled"] = "비활성"

L["header_playerLocation"] = "플레이어 위치 강조"
L["header_playerDirection"] = "플레이어 방향선"
L["header_misc"] = "기타"
L["descr_playerDirection"] = "플레이어가 바라보는 방향으로 선을 그립니다."
L["never"] = "사용 안 함"
L["always"] = "항상"
L["whileFlying"] = "비행 중에만"
L["colorStart"] = "시작"
L["colorEnd"] = "끝"
L["length"] = "길이"
L["thickness"] = "굵기"

L["Custom"] = "사용자 지정" -- new highlights that the user added
L["new"] = "새로 추가" -- add new custom highlight
L["rename"] = "이름 변경" -- rename custom highlight
L["delete"] = "삭제" -- delete custom highlight
L["copy"] = "다른 강조에서 설정 복사 ..." -- copy settings from one highlight to the current one
