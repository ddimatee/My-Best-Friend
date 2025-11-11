// JS sencillo para CRUD de Usuarios
(function(){
  const API = (localStorage.getItem('apiBase') || 'http://localhost:3000').replace(/\/$/, '');
  const el = (id) => document.getElementById(id);

  // Mostrar base del API
  const apiBaseEl = document.getElementById('apiBase');
  if (apiBaseEl) apiBaseEl.textContent = API;

  const statusEl = el('status');

  function formData() {
    return {
      nombre: el('nombre').value.trim(),
      apellido: el('apellido').value.trim(),
      correo: el('correo').value.trim(),
      password: el('password').value,
      celular: el('celular').value.trim(),
      fotoPerfil: el('fotoPerfil').value.trim() || undefined,
      direccion: el('direccion').value.trim() || undefined,
      rol: el('rol').value,
      fcmToken: el('fcmToken').value.trim() || undefined
    };
  }

  function setForm(data = {}) {
    el('_id').value = data._id || '';
    el('nombre').value = data.nombre || '';
    el('apellido').value = data.apellido || '';
    el('correo').value = data.correo || '';
    el('password').value = '';
    el('celular').value = data.celular || '';
    el('fotoPerfil').value = data.fotoPerfil || '';
    el('direccion').value = data.direccion || '';
    el('rol').value = data.rol || 'dueno';
    el('fcmToken').value = data.fcmToken || '';
  }

  function rowTemplate(u) {
    const fecha = u.fechaCreacion ? new Date(u.fechaCreacion).toLocaleDateString() : '-';
    return `<tr>
      <td>${u.nombre || ''} ${u.apellido || ''}<div class="mono muted">${u._id}</div></td>
      <td>${u.correo || '-'}</td>
      <td>${u.celular || '-'}</td>
      <td>${u.rol || 'dueno'}</td>
      <td>${fecha}</td>
      <td>
        <button class="btn" data-action="edit" data-id="${u._id}">Editar</button>
        <button class="btn btn-danger" data-action="del" data-id="${u._id}">Borrar</button>
        <button class="btn" data-action="token" data-id="${u._id}">Token</button>
      </td>
    </tr>`;
  }

  async function list() {
    try {
      const res = await fetch(`${API}/api/usuarios`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      if (!Array.isArray(data)) throw new Error('Respuesta inesperada del servidor');
      el('rows').innerHTML = data.map(rowTemplate).join('');
    } catch (e) {
      console.error('Error listando usuarios:', e);
      alert('No se pudieron cargar los usuarios. Ver consola para más detalles.');
    }
  }

  async function save() {
    const id = el('_id').value;
    const body = formData();
    if (statusEl) statusEl.textContent = 'Guardando...';
    try {
      let res;
      if (id) {
        res = await fetch(`${API}/api/usuarios/${id}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      } else {
        res = await fetch(`${API}/api/usuarios`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      }
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Error');
      await list();
      setForm({});
    } catch (e) {
      alert(e.message);
    } finally {
      if (statusEl) statusEl.textContent = '';
    }
  }

  async function removeItem(id) {
    if (!confirm('¿Borrar usuario?')) return;
    const res = await fetch(`${API}/api/usuarios/${id}`, { method: 'DELETE' });
    const data = await res.json();
    if (!res.ok) return alert(data.error || 'Error');
    list();
  }

  document.addEventListener('click', async (e) => {
    const btn = e.target.closest('button');
    if (!btn) return;
    if (btn.id === 'saveBtn') return save();
    if (btn.id === 'clearBtn') return setForm({});
    if (btn.id === 'refreshBtn') return list();
    const action = btn.dataset.action;
    const id = btn.dataset.id;
    if (action === 'edit') {
      try {
        const res = await fetch(`${API}/api/usuarios/${id}`);
        const data = await res.json();
        if (!res.ok) return alert(data.error || 'No encontrado');
        setForm(data);
      } catch (e) {
        alert('No fue posible obtener el usuario.');
      }
    }
    if (action === 'del') removeItem(id);
    if (action === 'token') {
      try {
        const res = await fetch(`${API}/api/usuarios/${id}/token`, { method: 'POST' });
        const data = await res.json();
        if (!res.ok) return alert(data.error || 'No se pudo generar token');
        // Mostrar token y también ponerlo en el input fcmToken para copiar fácil
        alert(`Token generado:\n${data.token}`);
        const fcm = document.getElementById('fcmToken');
        if (fcm) fcm.value = data.token;
      } catch (e) {
        alert('Error generando token');
      }
    }
  });

  // Primera carga
  list();
})();
