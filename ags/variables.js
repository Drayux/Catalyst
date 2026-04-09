import GLib from "gi://GLib"

// Used for date-related applets
// .format("%H:%M:%S")
export const clock = Variable(GLib.DateTime.new_now_local(), {
    poll: [1000, () => GLib.DateTime.new_now_local()],
})

// export const clock = Variable('', {
//     poll: [1000, 'date'],
// })
