import csv

priorities = {
    "STORY": 0,
    "RELEVANT": 1,
    "QUIP": 99
}

npc_dict = {}
dialogues = {}

with open("./list.csv", "r") as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        # Skip the header
        if reader.line_num != 1:
            if row[0] == '':
                break
            npc = row[0].lower()
            timeline = row[1]
            priority = row[2]
            unlocks = row[3].split(",")
            removes = row[4].split(",")
            bubble = True if row[5] == "TRUE" else False

            if npc not in npc_dict:
                npc_dict[npc] = dict()
            npc_dict[npc][timeline] = {
                "id": timeline,
                "priority": priorities[priority],
                "bubble": bubble
            }
            unlocked_ids = []
            removed_ids = []
            for full in unlocks:
                if full == '':
                    break
                split = full.split("-")
                unlocked_ids.append({
                    "dialogue_id": "-".join(split[1:]),
                    "npc_id": split[0]
                })
            for full in removes:
                if full == '':
                    break
                split = full.split("-")
                removed_ids.append({
                    "dialogue_id": "-".join(split[1:]),
                    "npc_id": split[0]
                })
            dialogues[timeline] = {
                "unlocked_ids": unlocked_ids,
                "removed_ids": removed_ids,
            }

for npc_name in npc_dict:
    with open('../%sDialogueFile.tres' % npc_name.title(), 'w') as f:
        text = '''[gd_resource type="Resource" load_steps=%d format=2]

[ext_resource path="res://Scripts/DialogueSystem/classes/DialogueFile.gd" type="Script" id=1]
[ext_resource path="res://Scripts/DialogueSystem/classes/Dialogue.gd" type="Script" id=2]
''' % (3 + len(npc_dict[npc_name]))
        dialogues_text = '''
[resource]
script = ExtResource( 1 )
dialogues = {'''
        count = 1
        for dialogue_name in npc_dict[npc_name]:
            dialogue = npc_dict[npc_name][dialogue_name]
            d_id = "-".join(dialogue_name.split("-")[1:])
            text += '''
[sub_resource type="Resource" id=%d]
script = ExtResource( 2 )
id = "%s"
priority = %d
bubble = %s   
''' % (count, d_id, dialogue["priority"], str(dialogue["bubble"]).lower())
            dialogues_text += '''
"%s": SubResource( %d )%s''' % (d_id, count, ''',''' if count <= len(npc_dict[npc_name]) - 1 else '''
}''')
            count += 1

        f.write(text + dialogues_text)

with open("../UnlockTable.tres", "w") as f:
    sub_resources = {}
    text = '''[gd_resource type="Resource" load_steps=%d format=2]

[ext_resource path="res://Scripts/DialogueSystem/classes/UnlockTable.gd" type="Script" id=1]
[ext_resource path="res://Scripts/DialogueSystem/classes/UnlockTableEntry.gd" type="Script" id=2]
[ext_resource path="res://Scripts/DialogueSystem/classes/DialogueNpcIds.gd" type="Script" id=3]
'''
    count = 1
    with open("./events.csv", "r") as events_file:
        reader = csv.reader(events_file)
        for row in reader:
            if reader.line_num != 1:
                if row[0] == '':
                    break
                timeline = row[0]
                unlocks = row[1].split(",")
                removes = row[2].split(",")

                unlocked_resource_ids = []
                removed_resource_ids = []
                for i in range(len(unlocks)):
                    full = unlocks[i]
                    if full == '':
                        break
                    split = full.split("-")
                    unlocked_resource_ids.append(count + i + 1)
                    text += '''
[sub_resource type="Resource" id=%d]
script = ExtResource( 3 )
dialogue_id = "%s"
npc_id = "%s"
''' % (count + i + 1, "-".join(split[1:]), split[0])
                for i in range(len(removes)):
                    full = removes[i]
                    if full == '':
                        break
                    split = full.split("-")
                    removed_resource_ids.append(count + i + len(unlocked_resource_ids) + 1)
                    text += '''
[sub_resource type="Resource" id=%d]
script = ExtResource( 3 )
dialogue_id = "%s"
npc_id = "%s"
''' % (count + i + len(unlocked_resource_ids) + 1, "-".join(split[1:]), split[0])

                text += '''
[sub_resource type="Resource" id=%d]
script = ExtResource( 2 )
unlocked_ids = [ ''' % count
                for i in range(len(unlocked_resource_ids)):
                    text += "SubResource( %d )%s" % (
                        unlocked_resource_ids[i], ", " if i < len(unlocked_resource_ids) - 1 else "")
                text += ''' ]
                removed_ids = [ '''
                for i in range(len(removed_resource_ids)):
                    text += "SubResource( %d )%s" % (
                        removed_resource_ids[i], ", " if i < len(removed_resource_ids) - 1 else "")

                text += ''' ]
                '''
                sub_resources[timeline] = count
                count += 1 + len(unlocked_resource_ids) + len(removed_resource_ids)

    for d in dialogues:
        unlocked_resource_ids = []
        removed_resource_ids = []
        for i in range(len(dialogues[d]["unlocked_ids"])):
            entry = dialogues[d]["unlocked_ids"][i]
            unlocked_resource_ids.append(count + i + 1)
            text += '''
[sub_resource type="Resource" id=%d]
script = ExtResource( 3 )
dialogue_id = "%s"
npc_id = "%s"
''' % (count + i + 1, entry["dialogue_id"], entry["npc_id"])
        for i in range(len(dialogues[d]["removed_ids"])):
            entry = dialogues[d]["removed_ids"][i]
            removed_resource_ids.append(count + i + len(unlocked_resource_ids) + 1)
            text += '''
[sub_resource type="Resource" id=%d]
script = ExtResource ( 3 )
dialogue_id = "%s"
npc_id = "%s"
''' % (count + i + len(unlocked_resource_ids) + 1, entry["dialogue_id"], entry["npc_id"])

        text += '''
[sub_resource type="Resource" id=%d]
script = ExtResource( 2 )
unlocked_ids = [ ''' % count
        for i in range(len(unlocked_resource_ids)):
            text += "SubResource( %d )%s" % (
                unlocked_resource_ids[i], ", " if i < len(unlocked_resource_ids) - 1 else "")
        text += ''' ]
removed_ids = [ '''
        for i in range(len(removed_resource_ids)):
            text += "SubResource( %d )%s" % (
                removed_resource_ids[i], ", " if i < len(unlocked_resource_ids) - 1 else "")

        text += ''' ]
'''
        sub_resources["npc-%s" % d] = count
        count += 1 + len(unlocked_resource_ids) + len(removed_resource_ids)

    text += '''
[resource]
script = ExtResource( 1 )
entries = {
'''
    keys = list(sub_resources.keys())
    for resource in range(len(keys)):
        text += '''"%s": SubResource( %d )%s''' % (keys[resource], sub_resources[keys[resource]], ''',
''' if resource < len(keys) - 1 else '''
}''')

    f.write(text % count)
